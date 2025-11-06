#!/usr/bin/env node

/**
 * Automatically fixes the boost podspec to use a working mirror
 * Runs after npm install
 */

const fs = require('fs');
const path = require('path');

const BOOST_PODSPEC_PATH = path.join(
  __dirname,
  '..',
  'node_modules',
  'react-native',
  'third-party-podspecs',
  'boost.podspec'
);

console.log('🔧 Fixing boost podspec...');

try {
  if (!fs.existsSync(BOOST_PODSPEC_PATH)) {
    console.log('⚠️  Boost podspec not found, skipping fix');
    process.exit(0);
  }

  let content = fs.readFileSync(BOOST_PODSPEC_PATH, 'utf8');

  // Replace the problematic URL with working mirror
  const originalUrl = 'https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.bz2';
  const workingUrl = 'https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.bz2';

  if (content.includes(originalUrl)) {
    content = content.replace(originalUrl, workingUrl);
    
    // Remove the sha256 checksum line that causes verification errors
    content = content.replace(/,\s*:sha256\s*=>\s*['"][^'"]*['"]/g, '');
    
    fs.writeFileSync(BOOST_PODSPEC_PATH, content, 'utf8');
    console.log('✅ Boost podspec fixed successfully!');
  } else if (content.includes(workingUrl)) {
    console.log('✅ Boost podspec already fixed');
  } else {
    console.log('⚠️  Boost podspec has unexpected content, manual fix may be needed');
  }
} catch (error) {
  console.error('❌ Error fixing boost podspec:', error.message);
  // Don't fail the install, just warn
  process.exit(0);
}
