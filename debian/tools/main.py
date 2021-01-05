'''
    Cheap hack to add the main name check
    without having to type all of the stuff.
'''

def name_is_main(instructions):
    if __name__ == "__main__":
        instructions()

