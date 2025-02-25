<script lang="ts">
    import "../app.css";
    import { type NavbarLink } from "./Navbar";

    interface NavbarProps {
        links?: NavbarLink[],
    }

    let { links=[{ name: "Home", href: "/" }] }: NavbarProps = $props();
</script>

<div class="mb-14">
    <div id="navbar" class="flex flex-row fixed top-0 left-0 z-50 w-full shadow-md bg-slate-800">
        {#each links as link}
            <a href={link.href} class="text-slate-200 px-6 py-4 hover:bg-slate-700">{link.name}</a>
        {/each}
    </div>
</div>

<style>
    
</style>