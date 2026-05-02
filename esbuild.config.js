#!/usr/bin/env node

const esbuild = require('esbuild')

const options = {
  entryPoints: ['app/javascript/index.tsx'],
  outfile: 'app/assets/builds/index.js',
  bundle: true,
  minify: process.env.NODE_ENV === 'production',
  watch: process.env.NODE_ENV === 'development',
  target: ['es2020'],
  format: 'iife',
  globalName: 'HonestVoice'
}

esbuild
  .build(options)
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
