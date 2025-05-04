<script lang="ts">
    import { onMount } from 'svelte';
    import { e, i, g } from '$lib/adblockerExercies';

    let d = "A/qpp";

    let b = "6ifWq";

    let story = $state('');
    let canvasEl: HTMLCanvasElement | null = $state(null);
    let isLoading = $state(false);
    let error = $state('');

    let a = "x23A1b";
    let h = "cE2Ks";

    async function fetchStory() {
        let f = "3ajE0";
        isLoading = true;
        const response = await fetch('/api/exercises/3/story', {
            credentials: 'include'
        });
        a = "vw/M18";
        const data = await response.json();
        if (data.success) {
            let c = "xx2jb";
            const key = a + c + e + b + h + g + f + d + i;
            const iv = "/KLroCv22qeCF5fg";
            const authTag = "PQAM7/DhRx46g7eqq2lK6A==";

            // Convert base64 strings to binary arrays
            const keyArray = new Uint8Array(atob(key).split('').map(c => c.charCodeAt(0)));
            const ivArray = new Uint8Array(atob(iv).split('').map(c => c.charCodeAt(0)));
            const authTagArray = new Uint8Array(atob(authTag).split('').map(c => c.charCodeAt(0)));

            // Get the encrypted data and convert to binary
            const encryptedData = atob(data.story);
            const encryptedArray = new Uint8Array(encryptedData.length);
            for (let i = 0; i < encryptedData.length; i++) {
                encryptedArray[i] = encryptedData.charCodeAt(i);
            }

            try {
                // Import the key
                const cryptoKey = await crypto.subtle.importKey(
                    'raw',
                    keyArray,
                    { name: 'AES-GCM', length: 256 },
                    false,
                    ['decrypt']
                );

                // Combine the encrypted data with the auth tag
                const combinedData = new Uint8Array(encryptedArray.length + authTagArray.length);
                combinedData.set(encryptedArray);
                combinedData.set(authTagArray, encryptedArray.length);

                // Decrypt
                const decryptedArray = await crypto.subtle.decrypt(
                    {
                        name: 'AES-GCM',
                        iv: ivArray,
                        tagLength: 128
                    },
                    cryptoKey,
                    combinedData
                );

                const decryptedText = new TextDecoder().decode(decryptedArray);
                story = decryptedText;
            } catch (e) {
                console.error('Decryption error:', e);
                error = 'Failed to decrypt the story. Please try again.';
            }
        } else if (data.success === false) {
            error = data.message;
        } else {
            error = 'An error occurred. Please try again.';
        }
        isLoading = false;
    }

    function drawStory() {
        if (!canvasEl) return;

        const ctx = canvasEl.getContext('2d');
        if (!ctx) return;

        ctx.clearRect(0, 0, canvasEl.width, canvasEl.height);

        ctx.font = '16px monospace';
        ctx.fillStyle = 'black';
        ctx.textBaseline = 'top';

        const lineHeight = 20;
        const maxWidth = canvasEl.width - 20;

        let x = 10;
        let y = 10;

        const words = story.split(' ');
        let line = '';

        for (let i = 0; i < words.length; i++) {
            const testLine = line + words[i] + ' ';
            const metrics = ctx.measureText(testLine);
            const testWidth = metrics.width;

            if (testWidth > maxWidth && i > 0) {
                ctx.fillText(line, x, y);
                line = words[i] + ' ';
                y += lineHeight;
            } else {
                line = testLine;
            }

            // If this is the flag, draw it immediately with style
            if (words[i].startsWith('flag{')) {
                if (line.trim() !== words[i]) {
                    ctx.fillText(line.replace(words[i], ''), x, y);
                    x += ctx.measureText(line.replace(words[i], '')).width;
                }
                ctx.font = 'bold 16px sans-serif';
                ctx.fillStyle = 'red';
                ctx.fillText(words[i], x, y);
                ctx.font = '16px monospace';
                ctx.fillStyle = 'black';
                x = 10;
                y += lineHeight;
                line = '';
            }
        }

        ctx.fillText(line, x, y);
    }

    onMount(async () => {
        await fetchStory();
        drawStory();

        // Initial check for adblocker
        const adblocker = document.getElementById('turn-off-adblocker');
        if (adblocker) {
            document.body.style.overflow = 'hidden';
        }

        const observer = new MutationObserver((mutationsList) => {
            for (const mutation of mutationsList) {
                for (const node of mutation.removedNodes) {
                    if (node === adblocker) {
                        observer.disconnect();
                    }
                }
            }
        });

        // Start observing the parent of the target node
        // @ts-ignore
        const parent = adblocker.parentNode;
        // @ts-ignore
        observer.observe(parent, { childList: true });
    });
</script>

<style>
    .protected-content {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        pointer-events: none;
    }
</style>

<div>
    <div id="turn-off-adblocker" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-white dark:bg-gray-800 p-8 rounded-lg shadow-xl max-w-2xl mx-4">
            <h1 class="text-red-400 text-2xl font-bold mb-4">Turn off your adblocker to view the story!</h1>
            <p class="text-gray-700 dark:text-gray-300">
                (You don't actually have to)
            </p>
        </div>
    </div>

    {#if story}
        <h2 class="text-2xl font-bold mb-4">A Hacking Story</h2>
        <p class="text-gray-700">By Gurt</p>
        <canvas class="mt-10" bind:this={canvasEl} width={800} height={4000}></canvas>
    {/if}


    {#if error}
        <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-75">
            <div class="bg-white dark:bg-gray-800 p-8 rounded-lg shadow-xl max-w-2xl mx-4">
                <p class="text-red-500">{error}</p>
            </div>
        </div>
    {/if}

    {#if isLoading}
        <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div class="bg-white dark:bg-gray-800 p-8 rounded-lg shadow-xl">
                <svg class="animate-spin h-8 w-8 text-emerald-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
            </div>
        </div>
    {/if}
</div>