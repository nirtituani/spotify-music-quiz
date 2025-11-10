const fs = require('fs');
const path = require('path');

const boostPath = path.join(__dirname, '../node_modules/react-native/third-party-podspecs/boost.podspec');

if (fs.existsSync(boostPath)) {
  let content = fs.readFileSync(boostPath, 'utf8');
  
  const originalUrl = 'https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.bz2';
  const workingUrl = 'https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.bz2';
  
  content = content.replace(originalUrl, workingUrl);
  content = content.replace(/,\s*:sha256\s*=>\s*['"][^'"]*['"]/g, '');
  
  fs.writeFileSync(boostPath, content);
  console.log('✅ Boost podspec fixed!');
} else {
  console.log('⚠️ Boost podspec not found');
}
