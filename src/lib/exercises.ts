import { supabase } from './supabaseClient';

// Retrieve exercises from the backend
export interface Exercise {
    exerciseId: number;
    title: string;
    difficultyId: number;
    points: number;
    solveCount: number;
    createdAt: string;
    description: string;
    hints: string[];
    tags: string[];
    categoryId: number;
}

export interface Difficulty {
    difficultyId: number;
    difficulty: string;
    displayColor: string;
}

export interface Category {
    categoryId: number;
    category: string;
    displayColor: string;
}

export async function getExercises(): Promise<Exercise[]> {
    const { data, error } = await supabase.from('exercises').select('exercise_id,title,difficulty_id,points,solve_count,created_at,description,hints,tags,category_id');
    if (error) {
        throw new Error(error.message);
    }

    return data.map(exercise => ({
        exerciseId: exercise.exercise_id,
        title: exercise.title,
        difficultyId: exercise.difficulty_id,
        points: exercise.points,
        solveCount: exercise.solve_count,
        createdAt: exercise.created_at,
        description: exercise.description,
        hints: exercise.hints,
        tags: exercise.tags,
        categoryId: exercise.category_id,
    }));
}

export async function getDifficulties(): Promise<Difficulty[]> {
    const { data, error } = await supabase.from('difficulties').select('difficulty_id,difficulty,display_color');
    if (error) {
        throw new Error(error.message);
    }
    return data.map(difficulty => ({
        difficultyId: difficulty.difficulty_id,
        difficulty: difficulty.difficulty,
        displayColor: difficulty.display_color,
    }));
}

export async function getCategories(): Promise<Category[]> {
    const { data, error } = await supabase.from('categories').select('category_id,category,display_color');
    if (error) {
        throw new Error(error.message);
    }
    return data.map(category => ({
        categoryId: category.category_id,
        category: category.category,
        displayColor: category.display_color,
    }));
}

export async function getExerciseCompletions(): Promise<number[]> {
    const { data, error } = await supabase.from('completions').select('exercise_id');
    if (error) {
        throw new Error(error.message);
    }
    return data.map(completion => completion.exercise_id);
}