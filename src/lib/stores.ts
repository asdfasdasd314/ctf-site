import { writable } from 'svelte/store';
import type { Exercise, Difficulty, Category } from './exercises';

export const exercisesStore = writable<Exercise[]>([]);
export const difficultiesStore = writable<Difficulty[]>([]);
export const categoriesStore = writable<Category[]>([]);