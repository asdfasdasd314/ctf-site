import { getExercises, getDifficulties, getCategories, type Exercise, type Difficulty, type Category } from '$lib/exercises';

export async function load() {
    // Fetch exercises, difficulties, and categories from the database on page load
    let exercises: Exercise[] = [];
    let difficulties: Difficulty[] = [];
    let categories: Category[] = [];

    try {
        exercises = await getExercises();
    } catch (error) {
        console.error('Error fetching exercises:', error);
    }
    try {
        difficulties = await getDifficulties();
    } catch (error) {
        console.error('Error fetching difficulties:', error);
    }
    try {
        categories = await getCategories();
    } catch (error) {
        console.error('Error fetching categories:', error);
    }

    return {
        exercises,
        difficulties,
        categories
    };
}