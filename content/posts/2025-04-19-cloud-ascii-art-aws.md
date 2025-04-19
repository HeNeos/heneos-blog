---
title: "AWS Ascii Art"
description: "Deploying an ascii art application in AWS"
tags: ["cloud", "image-processing"]
date: "2025-04-19"
---

It's been a long time since my last blog entry. I made a lot of progress on this and I finally feel satisfied with my architecture.

In the last entry I explained how to implement an `ascii art` application, however that is the local version, this one is about how to design the same idea but to deploy it in cloud environments.

You can think that's pretty straightforward if you already have the code, you can just deploy a EC2 or using ECS/EKS with an image of the code, and *yes*, you're right... that's probably the easiest way to do, however, I can't confirm if that's the most **optimal**.

Why?

Because in AWS you have many options to host your application, every service has a different limit/quota and price.

First question we have to answer is, what's our goal for our cloud application? I'm talking about the *-ilities* of the architecture, not about the application code.

1. Optimal cost (near to 0).
2. Reasonably scalable.
3. High elasticity.

Those are my goals for this cloud application, however I want to add an additional one, it's up to you if you consider it an `-ility`.

4. Mostly serverless

To accomplish the number 2 and 3, you can think to use EC2 and something like an **autoscaling group**, it could be based on `CPU` or `number of requests`.

Same approach could be used with EKS if you want to follow a Kubernetes approach.

However, none of them are serverless solutions and we have to keep an instace running 24/7, does it make sense?

You can feel tempted to use something like EC2 Spot Instances to reduce costs and then save money since this is not a critical application and it's ok if it takes longer to process the ascii art. However it's still not serverless.

Okay, then let's try with ECS Fargate. It's *serverless*, it means the container are scheduled when it's needed, when there's no requests we should have 0 instances running.

It's a better solution and we don't have to deal so much with the autoscaling and our application will be able to handle thousands of requests... but it fails in the number 3: `High elasticity`. Why??? Well, because unless you're optimizing the image for the application, it's gonna take a while to provide a container, I think it's not so high, but still it'll fail in the elasticity and it will add some delay to users.

So, it looks it's done for us, there's no a complete serverless service that can handle our ascii art application with our requirements, right?

Nope, I left the most foundational computing serverless service: `AWS Lambda`.

You could be concerned about some perks about using Lambda for this, but that's my goal here. I'm aiming to built a complete serverless computing service, keeping it scalable and with short processing times.

First, let's see how a solution using Lambda solves the *-ilities* we stated before.

1. Optimal cost: AWS Lambda provides us a generous free-tier.
2. Reasonably scalable: AWS Lambda has a concurrency limit of 1000.
3. High elasticity: AWS Lambda automatically scale-down and up based on demand, no limits under the 1000 concurrency limit.
4. Mostly serverless: AWS Lambda is a completely service.

## Schematizing cloud solution: Lambda functions

I'm going to start only for the image processing, because for the video... oh the video, it's way harder.

We can conceptualize the ascii art processing in two steps:

1. Resize the image.
2. Make the ascii art from resized image.

It looks fair simple, you can be tempted to do both steps in a single lambda, but hear is the trick. What about if I reword the steps to:

1. Resize the media.
2. Process frames.

Now it looks more like video, right? Actually both image and video are similar, and could be conceptualized as the same, the only issue is that video is computational more expensive, but we'll address that issue later.

It means, if we want to extend our architecture to video, it's better if we separate the steps in different lambdas. It also has another benefit that's we are gonna have less requirements for each lambda and then the image will be lighter, making that the lambda can initialize faster and we have a more specific way to provide memory and timeout limits for the lambdas.

We're gonna need some storage solution to save the resized image and the processed ascii art, since we want to keep this serverless and cost efficient the solution is obvious: `S3`.

Additionally, we need some orchestration tool so that our lambdas know what is the next step, another serverless solution: `Step functions`.

Until now, our architecture consists of an image stored in `S3`, then the `Step function` consists of two lambdas, the first one is gonna resize the image and save it in `S3`, then the process image lambda is gonna read the resized image and generate the ascii art, then save it in `S3`.

Let's start with the resize image lambda:

```py
MAX_HEIGHT: int = int(os.environ["MAX_HEIGHT"])

class LambdaEvent(TypedDict):
    key: str
    bucket_name: str

def rescale_image(image: Image.Image, height_to_resize: int) -> Image.Image:
    width, height = image.size

    resized_height: int = height_to_resize // Font.Height.value
    resized_width: int = int(
        resized_height * width * Font.Height.value / (Font.Width.value * height)
    )

    resized_image = image.resize((resized_width, resized_height))
    return resized_image

def lambda_handler(event: LambdaEvent, _: dict) -> dict:
    file_path: str = event["key"]
    bucket_name: str = event["bucket_name"]

    image_file: ImageFile = cast(ImageFile, find_media_type(file_path))

    resolution: int = min(int(response["resolution"]["S"]), MAX_HEIGHT)

    local_file: str = download_from_s3(s3_client, bucket_name, file_path)
    image: Image.Image = Image.open(local_file).convert("RGB")

    resized_image = rescale_image(image, resolution)
    resized_image_name = f"{image_file.random_id}/{image_file.file_name}_resized.{image_file.extension.value}"

    image_object: ImagePillow = ImagePillow(resized_image, image_file.extension)
    image_object.write_to_buffer()

    processed_key: str = image_object.save_image(
        s3_client,
        bucket_name,
        f"processed/{resized_image_name}",
    )
    return {
        "key": file_path,
        "is_video": False,
        "is_image": True,
        "bucket_name": bucket_name,
        "processed_key": processed_key,
        "resolution": resolution,
    }

```

pretty simple.

Next lambda is a bit more complicated but we already have our ascii code from local, so we should only modularized it correctly.

```py
class LambdaEvent(TypedDict):
    key: str
    processed_key: str
    is_video: bool


def lambda_handler(event: LambdaEvent, _: str) -> dict[str, int | str]:
    initial_key: str = event["key"]
    _, _, random_id = split_file_name(initial_key)
    file_path: str = event["processed_key"]

    media_file: MediaFile = find_media_type(file_path)
    local_file: str = download_from_s3(s3_client, MEDIA_BUCKET, file_path)

    image: Image.Image = Image.open(local_file).convert("RGB")
    width, height = image.size
    ascii_dict = get_ascii_dict(width, height, output)

    char_array = create_char_array(ascii_dict)
    ascii_image = ascii_convert(image, char_array)
    image_object: ImageCairo = ImageCairo(
        ascii_image, ImageExtension(media_file.extension)
    )
    image_object.write_to_buffer()
    key = image_object.save_image(
        s3_client,
        ASCII_ART_BUCKET,
        f"{random_id}/{media_file.file_name}_ascii.{media_file.extension.value}",
    )
    url: str = s3_client.generate_presigned_url(
        "get_object",
        Params={
            "Bucket": ASCII_ART_BUCKET,
            "Key": key,
        },
        ExpiresIn=300,
    )
    return {
        "statusCode": 200,
        "ascii_art_key": key,
        "body": dumps(cast(dict[str, str], {"url": url})),
    }
```

## Storing the art: S3

So far, we have our lambda functions and now we need a way to store images ~in the future it'll be used for videos too~.

There is actually not so much mistery here, it's just creating the buckets and that's it... well, just a bit more.

It's faster to explain it with the code, and for this project I'm gonna use `terraform`, it's not my favorite choice but, just give it a try for now.

```terraform
locals {
  buckets = {
    media = {
      name_prefix     = "media-bucket"
      expiration_days = 1
    },
    audio = {
      name_prefix     = "audio-bucket"
      expiration_days = 1
    },
    ascii_art = {
      name_prefix     = "ascii-art-bucket"
      expiration_days = 1
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  for_each = local.buckets
  bucket = "${each.value.name_prefix}-${var.stage}-${var.account_id}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = local.buckets
  bucket = aws_s3_bucket.bucket[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "buckets_config" {
  for_each = local.buckets
  bucket = aws_s3_bucket.bucket[each.key].id
  rule {
    id = "Delete old files"
    expiration {
      days = each.value.expiration_days
    }
    noncurrent_version_expiration {
      noncurrent_days = each.value.expiration_days
    }
    filter {}
    status = "Enabled"
  }
  rule {
    id = "Delete deletion markers"
    expiration {
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      noncurrent_days = each.value.expiration_days
    }
    filter {}
    status = "Enabled"
  }
}
```

the only configuration for the buckets is enabling the versioning and adding a lifecycle configuration to delete the files after 1 day.

That way we're not going to spend so much money storing old assets and we could keep under the 5GiB that are in the S3 free tier.

## Orchestrating: Step functions

We require some way to indicate our lambda functions how they should *flow*, this process is called `orchestration` and I'm gonna use `step functions` to accomplish this.

This is a `long long` definition, so I'll trim it and keep the only part needed for the image, please also keep in mind this is just a *draft* and not the actual code. Also, you have to figure out by your own the required IAM permissions to make it work.

```terraform
resource "aws_sfn_state_machine" "step_function" {
  name     = "AsciiArt-${var.stage}"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<-DEFINITION
  {
    "Comment": "AsciiArt State Machine",
    "StartAt": "ExtractFileExtension",
    "States": {
      "ExtractFileExtension": {
        "Type": "Pass",
        "ResultPath": "$.fileExtension",
        "Parameters": {
          "key.$": "$.detail.object.key",
          "bucket_name.$": "$.detail.bucket.name",
          "extension.$": "States.ArrayGetItem(States.StringSplit($.detail.object.key, '.'), States.MathAdd(States.ArrayLength(States.StringSplit($.detail.object.key, '.')), -1))"
        },
        "Next": "IsVideo"
      },
      "IsVideo": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.is_video",
            "BooleanEquals": true,
            "Next": "DownsizeVideo"
          },
          {
            "Variable": "$.is_image",
            "BooleanEquals": true,
            "Next": "DownsizeMedia"
          }
        ],
        "Default": "NotSupported"
      },
      "DownsizeMedia": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.downsize_media.arn}",
        "Next": "ProcessImage"
      },
      "ProcessImage": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.process_image.arn}",
        "End": true
      },
    }
  }
  DEFINITION
}
```
