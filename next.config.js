/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  basePath: "/heneos-blog",
  assetPrefix: "/heneos-blog",
  images: {
    unoptimized: true,
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
        pathname: '**',
      },
    ],
  },
  typescript: {
    ignoreBuildErrors: true,
  },
};

module.exports = nextConfig;
