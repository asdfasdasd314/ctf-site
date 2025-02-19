<script lang="ts">
	import '../app.css';
	import Navbar from '$lib/Navbar.svelte';
	let { children } = $props();
</script>

<Navbar links={[{name: "Home", href: "/"}, {name: "CTF", href: "/ctf"}, {name: "Exercises", href: "/ctf/exercises"}]} />
{@render children()}
