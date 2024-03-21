password = input('What is your password?: ')
result = {}

if len(password) >= 8:
    result['Lenght'] = True

else:
    result['Lenght'] = False

digit = False
for n in password:
    if n.isdigit():
        digit = True
result['Digits'] = digit

uppercase = False
for c in password:
    if c.isupper():
        uppercase = True
result['Upper-case'] = uppercase

if all(result.values()):
    print('Your password is strong.')
else:
    print('Very weak password.')
print(result)