<script lang="ts">
    import { onMount } from 'svelte';
    import { getExercises } from '$lib/exercises';

	let { children } = $props();

    onMount(async () => {
        const _ = await getExercises(); // load the exercises into the store
    });
</script>

{@render children()}