// https://stackoverflow.com/a/52575123/2066546

const build_command = "bash -v -e ./install.sh"

const execSync = require('child_process').execSync;
// import { execSync } from 'child_process';  // replace ^ if using ES modules

execSync(build_command, { encoding: 'utf-8', stdio: 'inherit' });  // the default is 'buffer'

