import {PipeSession} from 'potpiper';

let lua0 = new PipeSession('luajit',['logic.lua']);
//console.log(lua0);
let test = await lua0.send('hello world\n');
test = await lua0.send('hello world\n');
console.log(test);
lua0.close()