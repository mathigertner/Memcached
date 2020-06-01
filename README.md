# Memcached

## Getting Started

To run the server, go to terminal and type the following commands from the project root:
```
cd lib
cd server
ruby memcached.rb
```

To run the demo client, go to terminal and type the following commands from the project root:
```
cd lib
ruby client.rb
```

## Sample Commands

This is a guide to issue sample commands from the demo client terminal:

###### Set
In the following example, we use 'foo' as the key and set value 'bar' in it with an expiration time of 500 seconds.
```
set foo 0 500 3
bar
STORED
get foo
VALUE foo 0 3
bar
END
```

###### Add
In the following example, we use ‘foo’ as the key and add the value 'bar' in it with an expiration time of 500 seconds.
```
add foo 0 500 3
bar
STORED
get foo
VALUE key 0 3
bar
END
```

###### Replace
In the following example, we use ‘foo’ as the key and store 'bar' in it with an expiration time of 500 seconds. After this, the same key is replaced with the value ‘new’.
```
add foo 0 500 3
bar
STORED
get foo
VALUE foo 0 3
bar
END
replace foo 0 500 3
new
get foo
VALUE key 0 3
new
END
```

###### Append
In the following example, we try to add some data in a key that does not exist. Thus, Memcached returns NOT_STORED. After this, we set one key and append data into it.
```
append foo 0 500 1
z
NOT_STORED
set foo 0 500 3
bar
STORED
get foo
VALUE foo 0 3
bar
END
append foo 0 500 1
z
STORED
get foo
VALUE foo 0 4
barz
END
```

###### Prepend
In the following example, we try to add some data in a key that does not exist. Thus, Memcached returns NOT_STORED. After this, we set one key and prepend data into it.
```
prepend foo 0 500 1
a
NOT_STORED
set foo 0 500 3
bar
STORED
get foo
VALUE foo 0 3
bar
END
prepend foo 0 500 1
a
STORED
get foo
VALUE foo 0 4
abar
END
```

###### CAS
To execute a CAS command in Memcached, you need to get a CAS token from the Memcached gets command.
```
set foo 0 500 3
bar
STORED
gets foo
VALUE foo 0 3 1
bar
END
cas foo 0 500 7 2
updated
EXISTS
cas foo 0 500 7 1
updated
STORED
get foo
VALUE foo 0 7
updated
END
```

###### Get
In the following example, we use foo as the key and store bar in it with an expiration time of 500 seconds.
```
set foo 0 500 3
bar
STORED
get foo
VALUE foo 0 3
bar
END
```

###### Gets 
Memcached gets command is used to get the value with CAS token. If the key does not exist in Memcached, then it returns nothing.
```
set foo 0 500 3
bar
STORED
gets foo
VALUE foo 0 3 1
bar
END
```

## Running the tests

To run the system automated tests, go to terminal and type the following command from the project root:
```
rspec spec
```

## Author

* **Mathias Gertner** - *Initial work* - [Memcached](https://github.com/mathigertner/Memcached)
