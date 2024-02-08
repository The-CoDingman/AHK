This class takes three different images and combines them into a functional Toggle Button.
You can use this class with both uncompiled and compiled scripts.
For Compiled Scripts, you'll need to add your images via a FileInstall
    The recommend way to do this is inside of a function that you never call, 
    this allows the files to be compiled into the .exe but never actually get installed onto the user's system
    InternalResources() {
        FileInstall(<filepath>, "*")
    }

Your images need to be saved with specific filenames, you'll give them all the same base name such as "Button1"
and then you'll need to give them suffixes so the class knows which order to display the images.
Example: 
    Basename: Button1.png
    Default: The image that is displayed when not clicked or hovered -- Button1_default.png
    Hover: The image that is displayed when the user hovers over the button -- Button1_hover.png
    Click: The image that is displayed when the user clicks the button -- Button1_click.png
    When you call the class, you will just supply the Basename with the file extension,
    and the class will know to look for the three individual images
        Button1 := ImageButton(MyGui, "x+10 y+10", "Button1.png")


NOTES:  To prevent image flickering present in the usual attempts to create image buttons,
        styles are added to the GUI that affect the draw order of images.  Because of this,
        if you want to use an image for the background of your GUI, you'll need to add the
        background at the end after all the other images have been created.
