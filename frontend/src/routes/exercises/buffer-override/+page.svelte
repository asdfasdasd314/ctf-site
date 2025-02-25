<script lang="ts">
    import "../../../app.css";
    import HowTo from "$lib/HowTo.svelte";
	import { onMount } from "svelte";

    let buff1 = $state("");

    interface Buffers {
        buffer1: string,
        buffer2: string,
        ptr1: bigint, // as memory performance is not a consideration right now, these can be bigints even though I think this isn't actually efficient
        ptr2: bigint
    }

    let buffers: Buffers | null = $state(null);

    // For now just use stateful variable, but this would be changed to a web socket for more security
    let broken = $state(false);

    onMount(async () => {
        await fetch("/api/buffer-override/setup", {
            method: "PUT",
        });

        await updateBuffers();
    });

    const getBuffers = async () => {
        const response = await fetch('/api/buffer-override/get-buffers', {
            method: "GET",
        });

        const json = await response.json();
        return json;
    }

    const updateBuffers = async () => {
        const json = await getBuffers();
        buffers = { buffer1: json.buffer1, buffer2: json.buffer2, ptr1: json.ptr1, ptr2: json.ptr2 }; 
    }

    const setBuffer1 = async () => {
        if (buff1 === "") {
            buff1 = "Buffer1";
        }

        await fetch(`/api/buffer-override/set-buffer1?buff=${buff1}`, {
            method: "POST",
        });

        updateBuffers();
    }

    // Call exit if buffer2 has been tampered with
    const checkForCorruption= async (): Promise<boolean> => {
        // Yes, this could be exploited on the frontend, and all the checks would need to be done on the backend, but that takes a bit to set up on both sides, so I will do that later
        if (buffers && buffers.buffer2 != "Unbreakable!") {
            await exit(); // Free the memory on the server
            broken = true;
            return true;
        }

        broken = false;
        return false;
    }
    

    const exit = async () => {
        await fetch("/api/buffer-override/exit", {
            method: "PUT",
        });
    }
</script>

<div id="body">
    <div id="metadata" class="flex flex-col">
        <h1>Practice Buffer Override</h1>
    </div>
    <div id="how-to-container" class="flex flex-col">
        <HowTo guide={"Try to change the second buffer!"} />
    </div>
</div>
    <div id="exercise">
        <div id="heap">
            {#if buffers != null}
                <table class="border-separate border-spacing-4">
                    <thead>
                        <tr>
                            <th>Buffers</th>
                            <th>Memory Addresses</th>
                        </tr>
                    </thead>
                    <tbody>
                            <tr>
                                <td>{buffers.buffer1}</td>
                                <td>{"0x" + buffers.ptr1.toString(16)}</td>
                            </tr>
                            <tr>
                                <td>{buffers.buffer2}</td>
                                <td>{"0x" + buffers.ptr2.toString(16)}</td>
                            </tr>
                    </tbody>
                </table>
            {:else}
                <p>Buffers were not initialized (server error)</p>
            {/if}
        </div>
        <div id="menu">
            <input class="border pt-2 pb-2" bind:value={buff1} />
            <button class="p-2 border-1 border-black" onclick={setBuffer1}>Set Buffer 1</button>
            <button class="p-2 border-1 border-black" onclick={updateBuffers}>Update Heap</button>
            <button class="p-2 border-1 border-black" onclick={checkForCorruption}>Check if Buffer2 has changed</button>
        </div>
        {#if broken}
            <p>You completed the challenge!</p>
        {/if}
    </div>
    <div id="hints">
        
    </div>
<style>
</style>