<script lang="ts">
	import '../app.css';
	import Navbar from '$lib/Navbar.svelte';
	let { children } = $props();
</script>

<Navbar links={[{name: "What is CTF?", href: "/"}, {name: "Exercises", href: "/exercises"}]} />
{@render children()}
