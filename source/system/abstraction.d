module system.abstraction;

import std.stdio;

nothrow void debugWriteln(A...)(A args)
{
    debug
    {
        try
        {
            writeln("INFO: ENGINE: ", args);
        }
        catch (Exception e)
        {

        }
    }
}