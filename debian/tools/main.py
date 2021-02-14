'''
    Cheap hack to add the main name check
    without having to type all of the stuff.
'''

def main_if_main(instructions, *positional, **args):
    if __name__ == "__main__":
        instructions(*positional, **args)
