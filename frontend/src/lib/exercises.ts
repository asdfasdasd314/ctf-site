// Retrieve exercises from the backend

export interface Exercise {
    exerciseId: number;
    category: string;
    title: string;
    difficulty: string;
    points: number;
    solveCount: number;
    createdAt: string;
    description: string;
    tags: string[];
    hints: string[];
    isCompleted: boolean;
}

export async function getExercises(): Promise<Exercise[]> {
    const response = await fetch('/api/exercises');
    const data = await response.json();
    if (data.success) {
        const exercises: Exercise[] = [];
        for (const exercise of data.exercises) {
            // Have to make this conversion because I want the Zig code to have Zig standards and TS to have TS standards
            const newExercise: Exercise = {
                exerciseId: exercise.exercise_id,
                category: exercise.category,
                title: exercise.title,
                difficulty: exercise.difficulty,
                points: exercise.points,
                solveCount: exercise.solve_count,
                createdAt: exercise.create_at,
                description: exercise.description,
                tags: exercise.tags.split(","),
                hints: exercise.hints,
                isCompleted: false,
            };
            newExercise.isCompleted = await checkSolved(newExercise.exerciseId);
            exercises.push(newExercise);
        }
        return exercises;
    } else {
        throw new Error(data.message);
    }
}

export async function checkSolved(exerciseId: number): Promise<boolean> {
    const res = await fetch(`/api/exercises/check-solved`, {
        method: 'POST',
        body: JSON.stringify({ exercise_id: exerciseId }),
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' }
    });
    const data = await res.json();
    if (data.success) {
        return data.solved;
    } else {
        throw new Error(data.err);
    }
}