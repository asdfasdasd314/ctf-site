<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.css';
	import { supabase } from './supabaseClient';

	let leftLinks = [
		{ name: 'Home', href: '/' },
		{ name: 'Exercises', href: '/exercises' },
		{ name: 'About', href: '/about' },
		{ name: 'Support', href: '/support' },
	];

	let rightLinks: { name: string; href: string }[] = $state([{ name: 'Login', href: '/login' }, { name: 'Sign Up', href: '/signup' }]);

	onMount(async() => {
		const { data, error } = await supabase.auth.getSession();
		if (error) {
			console.error('Error getting session:', error);
		} else if (data.session) {
			rightLinks = [{ name: 'Dashboard', href: '/dashboard' }];
		}

		supabase.auth.onAuthStateChange((event, session) => {
			if (event === 'SIGNED_IN') {
				rightLinks = [{ name: 'Dashboard', href: '/dashboard' }];
			} else if (event === 'SIGNED_OUT') {
				rightLinks = [{ name: 'Login', href: '/login' }, { name: 'Sign Up', href: '/signup' }];
			}
		});
	});
</script>

<div class="mb-14">
	<div id="navbar" class="flex flex-row fixed top-0 left-0 z-100 w-full shadow-md bg-slate-800">
		<div class="flex flex-row mr-auto">
			{#each leftLinks as link}
				<a href={link.href} class="text-slate-200 px-6 py-4 hover:bg-slate-700" onclick={() => document.body.style.overflow = 'auto'}>{link.name}</a>
			{/each}
		</div>
		<div class="flex flex-row ml-auto">
			{#each rightLinks as link}
				<a href={link.href} class="text-slate-200 px-6 py-4 hover:bg-slate-700" onclick={() => document.body.style.overflow = 'auto'}>{link.name}</a>
			{/each}
		</div>
	</div>
</div>

<style>
</style>

