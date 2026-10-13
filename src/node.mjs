import fs from "node:fs";
import path from "node:path";

export function list_directory(directory) {
  return fs.readdirSync(directory).join("\n");
}

export function read_file(file_path) {
  return fs.readFileSync(file_path, "utf8");
}

export function write_file(file_path, contents) {
  fs.mkdirSync(path.dirname(file_path), { recursive: true });
  fs.writeFileSync(file_path, contents);
}

export function reset_output(directory) {
  fs.rmSync(directory, { recursive: true, force: true });
  fs.mkdirSync(directory, { recursive: true });
}

export function copy_file(source_path, destination_path) {
  fs.mkdirSync(path.dirname(destination_path), { recursive: true });
  fs.copyFileSync(source_path, destination_path);
}

export function copy_directory(source_path, destination_path) {
  fs.cpSync(source_path, destination_path, { recursive: true });
}

export function format_date(date_value) {
  return new Date(date_value).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
    timeZone: "UTC",
  });
}

export function format_short_date(date_value) {
  return new Date(date_value).toLocaleDateString("en-US", { timeZone: "UTC" });
}
