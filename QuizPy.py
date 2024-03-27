import json


with open('quizback.json', 'r') as file:
    content = file.read()

score = 0
data = json.loads(content)
for questions in data:
    print(questions["question"])
    for index, answer in enumerate(questions["answers"]):
        print(index + 1, '-', answer)
    user_input = int(input('Enter your answer: '))
    questions["user_input"] = user_input
    if questions["user_input"] == questions["correct answer"]:
        score = score + 1
        result = 'Correct answer'
    else:
        result = 'Wrong answer'
for index, questions in enumerate(data): 
    message = f'{index + 1} {result} - Your answer: {questions["user_input"]}, Correct answer: {questions['correct answer']}'
    print(message)
    
print(score, '/', len(data))