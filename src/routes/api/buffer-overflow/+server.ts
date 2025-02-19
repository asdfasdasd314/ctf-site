import { json } from '@sveltejs/kit';
import { dlopen, CString, FFIType } from "bun:ffi";

export function GET({}): Response {
    // I don't plan to ever run this on Windows
    const path = './example.so';

    const lib = dlopen(path, {
        get_app_state: { args: [], returns: FFIType.ptr },
    });

    const statePtr = lib.symbols.get_app_state();

    const num_ptrs = 2;
    const ptrs = [];
    const strings = [];
    for (let i = 0; i < num_ptrs; i++) {
        //@ts-ignore
        const strPtr = statePtr + i * 8; // 8 is for 64-bit operating system, likely 4 for 32 bit
        ptrs.push(strPtr);
        //@ts-ignore
        strings.push(new CString(strPtr));
    }

    console.log(ptrs);
    console.log(strings);

    return json("Good");
}