The proposal only details destructuring in the context of assignment, such as in variable assignments/declarations, or in loops. But I'm seeing quite a potential here for using destructuring in the context of function/constructor/accessor arguments, as is the case in Python.
# Examples
*These examples have all been written in Python.*
## Iterable unpacking
```python
def my_function(x, y):
  print(x)
  print(y)

my_tuple = (1, 2)

my_function(*my_tuple)
```
This prints the following;
```
1
2
```
## Mapping unpacking
```python
def my_function(x, y):
  print(x)
  print(y)

my_dictionary = {'x':1, 'y':2}

my_function(**my_dictionary)
```
This prints the following;
```
1
2
```
It also works in reverse;
```python
my_dictionary = {'y':2, 'x':1}

my_function (**my_dictionary)
```
This will print the following
```
1
2
```
**NOTE** *See the Python specifications for a more comprehensive look at the "unpacking" functionality*
# Issue
The problem that this concept poses, is the proposal's lack of an operator like the `*` or `**` operators from Python. This lack of operators means there's no distinguishment between destructuring a value to parameters and passing the value itself as an argument.