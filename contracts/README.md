Pardon the nature of my commit messages, i messed it up somehow. Even the projects are not organised as i want it to be.
i have realised my mistakes and i will make my new repos much better and organised.


ArithmeticOperations Contract

This Solidity contract provides basic arithmetic operations: 
addition, subtraction, multiplication, and division. 
It includes error handling to manage cases such as division by zero and subtracting a larger number from a smaller one.

Functions

add(uint a, uint b):
Returns the sum of a and b.
Example: add(10, 5) returns 15.

subtract(uint a, uint b):
Returns the difference of a - b. If b is greater than a, it returns the negative correspondence.
Example: subtract(10, 5) returns 5; subtract(5, 10) returns -5.

multiply(uint a, uint b):
Returns the product of a and b.
Example: multiply(10, 5) returns 50.

divide(uint a, uint b):
Returns the quotient of a / b. Throws an error if b is 0.
Example: divide(10, 5) returns 2; divide(10, 0) reverts with an error.

Conclusion
The ArithmeticOperations contract provides a simple and effective way to perform arithmetic operations on unsigned integers, with proper handling for edge cases to ensure reliability and correctness.
