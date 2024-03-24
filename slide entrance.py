feet_inches = input("What is your kid's height? ")

def convert(feet_inches):
    parts = feet_inches.split(' ')
    feet = parts[0]
    inches = parts[1]
    meters = float(feet) * 0.3048 + float(inches) * 0.0254
    return meters

result = convert(feet_inches)

print(f"Your kid's height is {result.__round__(2)} meters.")

if result < 1:
    print('Your kid cannot use the slide')
else:
    print('Your kid is allowed to use the slide, enjoy yourselves!')
