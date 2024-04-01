import function
import PySimpleGUI as sg
import time 


sg.theme('DarkTeal7')

timekeeper = sg.Text('', key='clock')
label = sg.Text("What are your encouragements of today?")
input_box = sg.InputText(tooltip='Enter affirmation', key='affirmation')
add_button = sg.Button('Add', size=15)
list_box = sg.Listbox(values=function.get_affirmations(), key='affirmations',
                       enable_events=True, size=[43, 5])
edit_box = sg.Button('Edit', size=6)
complete_box = sg.Button('Complete', size=8)
exit_box = sg.Button('Exit', size=10)

window = sg.Window('My Affirmations App', 
                   layout=[[timekeeper],
                       [label], [input_box, add_button],
                           [list_box, edit_box, complete_box],
                           [exit_box]],
                   font=('Kristen', 10))

while True:
    event, values = window.read(timeout=333)
    window['clock'].update(value=time.strftime("%b %d, %Y %H:%M:%S"))
    print(event)
    print(values)
    match event:
        case 'Add':
            affirmations = function.get_affirmations()
            new_affirmation = values['affirmation'] + '\n'
            affirmations.append(new_affirmation)
            function.write_affirmations(affirmations)
            window['affirmations'].update(values=affirmations)

        case 'Edit':
            try:
                affirmation_edit = values['affirmations'][0]
                new_affirmation = values['affirmation']

                affirmations = function.get_affirmations()
                index = affirmations.index(affirmation_edit)
                affirmations[index] = new_affirmation
                function.write_affirmations(affirmations)
                window['affirmations'].update(values=affirmations)
            except IndexError:
                sg.popup('Please select an item first.', font=('Kristen', 15))

        case 'Complete':
            try:
                affirmation_complete = values['affirmations'][0]
                affirmations = function.get_affirmations()
                affirmations.remove(affirmation_complete)
                function.write_affirmations(affirmations)
                window['affirmations'].update(values=affirmations)
                window['affirmation'].update(value='')
            except IndexError:
                sg.popup('Please select an item first.', font=('Kristen', 15))

        case 'Exit':
            break

        case sg.WIN_CLOSED:
            break

        case 'affirmations':
            window['affirmation'].update(value=values['affirmations'][0])

window.close()