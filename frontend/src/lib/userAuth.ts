import { writable } from 'svelte/store';

export const loggedIn = writable<boolean>(false);

export async function checkAuth(): Promise<boolean> {
    try {
        const res = await fetch('/api/validate-session', {
            method: 'GET',
            credentials: 'include',
            headers: { 'Content-Type': 'application/json' },
        });

        const data = await res.json();
        if (data.success) {
            loggedIn.set(true);
        }
        else {
            loggedIn.set(false);
        }

        return data.success;
    } catch (err) {
        loggedIn.set(false);
        console.error('Session check failed:', err);
        return false;
    }
}
