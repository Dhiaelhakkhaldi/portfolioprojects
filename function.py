FILEPATH = 'affirmations.txt'


def get_affirmations(filepath=FILEPATH):
    """ Read a text file and return the list of 
    affirmation items.
    """
    with open(filepath, 'r') as file_local:
            affirmations_local = file_local.readlines()
    return affirmations_local


def write_affirmations(affirmations_arg, filepath=FILEPATH):
    """ Write the affirmation items list in the text 
    file.
    """
    with open(filepath, 'w') as file_write:
                file_write.writelines(affirmations_arg)
      