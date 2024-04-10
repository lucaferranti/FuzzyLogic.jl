# Print Hello World
println("Hello, World!\n")
println("Choose your Fuzzy membership function: \n1-Triangular Membership Function\n2-Trapezoidal Membership Function\n3-Gaussian Membership Function")

Choose = readline()
Choose_int = parse(Int, Choose) # Convert string to integer
println("You have chosen $Choose")

if Choose_int == 1
  println("You have chosen Triangular Membership Function")
elseif Choose_int == 2
  println("You have chosen Trapezoidal Membership Function")
elseif Choose_int == 3
  println("You have chosen Gaussian Membership Function")
else
  println("Invalid choice.")
end
