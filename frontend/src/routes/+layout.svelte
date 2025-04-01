<script lang="ts">
	import '../app.css';
	import Navbar from '$lib/Navbar.svelte';
	import * as auth from '$lib/userAuth';
	import { onMount } from 'svelte';
	let { children } = $props();

	onMount(async () => {
		await auth.checkAuth();
	});
</script>

<Navbar />
{@render children()}