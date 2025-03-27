import withVideos from 'next-videos';
import { NextConfig } from 'next';

/** @type {NextConfig} */
const nextConfig: NextConfig = {
  // Your existing configuration options here
};

module.exports = {
  reactStrictMode: true,
  env: {
    SITE_NAME: "GoSafe AI",
  },
}

export default withVideos(nextConfig);

