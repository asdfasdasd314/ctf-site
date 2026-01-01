<script lang="ts">
    import { onMount } from 'svelte';

    let flag = $state("flag{I_haven't_been_solved_yet...}");
    let story = $derived(`Once upon a time, three hackers were trying to hack the secret system. They hacked and hacked as hard as they could, but they couldn't get the flag. But one day the youngest hacker decided to tweak the HTML on the page and changed a single variable in JavaScript, and the flag was revealed: ${flag}`);
    let canvasEl: HTMLCanvasElement | null = $state(null);
    let isLoading = $state(false);
    let error = $state('');

    async function fetchStory() {
        isLoading = true;
        const response = await fetch('/api/exercises/3/encrypted-flag', {
            credentials: 'include'
        });
        const data = await response.json();
        if (response.ok) {
            const keyArray = new Uint8Array(data.keyArray.split(',').map((c: string) => Number(c)));
            const ivArray = new Uint8Array(data.ivArray.split(',').map(Number));
            const authTagArray = new Uint8Array(data.authTagArray.split(',').map(Number));
            const encryptedArray = new Uint8Array(data.encryptedArray.split(',').map(Number));

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
                flag = decryptedText;
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

        const lineHeight = 100;
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
        drawStory();

        document.body.style.overflow = 'hidden';
        const observer = new MutationObserver(async (mutations) => {
            for (const mutation of mutations) {
                if (
                    mutation.type === 'attributes' &&
                    mutation.attributeName === 'style'
                ) {
                    if (document.body.style.overflow !== 'hidden') {
                        await fetchStory();
                        drawStory();
                    }
                }
            }
        });
        observer.observe(document.body, {
        attributes: true,
        attributeFilter: ['style']
        });
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
        <h2 class="text-5xl font-bold mb-12 mt-40 text-center">A Hacking Story</h2>
        <p class="text-gray-700 text-xl text-center">By Gurt</p>
        <p class="text-gray-700 text-xl mt-100 mb-160 text-center">Scroll down to read the story...</p>
        <canvas bind:this={canvasEl} width={600} height={800}></canvas>
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