<script lang="ts">
	import '../app.css';
	import Navbar from '$lib/Navbar.svelte';
	import { exercisesStore, difficultiesStore, categoriesStore } from '$lib/stores';
	let { children, data } = $props();

    exercisesStore.set(data.exercises);
    difficultiesStore.set(data.difficulties);
    categoriesStore.set(data.categories);
</script>

<!-- This is going to be subject to change, this is what I want right now -->
<!-- {#if !$page.url.pathname.startsWith('/exercises')}
	<Navbar />
{/if} -->

<Navbar />

{@render children()}

