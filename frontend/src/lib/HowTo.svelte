<script lang="ts">
	import '../app.css';

	interface HowToProps {
		guide?: string;
		imgPath?: string | null;
		imgAlt?: string;
	}

	const { guide = '', imgPath = null, imgAlt = '' }: HowToProps = $props();
</script>

<div id="how-to">
	<p>{guide}</p>
	{#if imgPath}
		<img src={imgPath} alt={imgAlt} />
	{/if}
</div>

<style>
</style>

