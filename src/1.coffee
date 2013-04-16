a = ()->
  x=1

  f = ()->
    x=0
    console.log x 

    x++
    console.log x 

  f()

a()
