export const Scoreboard = class {
    constructor() {
        this.scores = {};
    }

    setScore(userId, username, score) {
        // score = {'correct' : [], 'incorrect' : [], 'timeout' : []}
        this.scores[userId] = {'username' : username, 'score' : score};
    }

    clearAll() {
        this.scores = {};
    }

    isScorePresent(userId) {
        return userId in this.scores;
    }

    scoreCount() {
        return Object.keys(this.scores).length;
    }
}

export const Quiz = class {
    constructor(topic) {
        this.topic = topic;         // name of topic
        this.questions = [];        // list of QuizQuestions
        this.scoreboard = new Scoreboard();       // SCOREBOARD
        this.status = 'idle';       // idle or running
    }

    addQuestion(question) {
        this.questions.push(question);
    } 
    getNumberOfQuestions() {
        return this.questions.length;
    }
    static fromJSON(quizJson) {
        var quiz = new Quiz(quizJson['topic']);
        quizJson['questions'].forEach(question => {
            quiz.addQuestion(new QuizQuestion(question['statement'], question['image_url'], question['choices'], question['answer'], question['timer']));
        });
        return quiz;
    }
}

export const QuizQuestion = class {

    // statement: string, options: list of strings
    constructor(statement, imageUrl, choices, answer, timer) {
        this.statement = statement;
        this.imageUrl = imageUrl;
        this.choices = choices;
        this.answer = answer;       // answer is the choice number
        this.timer = timer;         // timer is time allowed for this question in seconds
    }


}