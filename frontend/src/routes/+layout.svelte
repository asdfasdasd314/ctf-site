<script lang="ts">
	import '../app.css';
	import Navbar from '$lib/Navbar.svelte';
	import * as auth from '$lib/userAuth';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	let { children } = $props();

	onMount(async () => {
		await auth.checkAuth();
	});
</script>

{#if !$page.url.pathname.startsWith('/exercises')}
	<Navbar />
{/if}
{@render children()}