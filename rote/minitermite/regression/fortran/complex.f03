program complex 
  complex :: x 
  x = cmplx(0.0,1.0) 
  call func(x)               

contains 
  subroutine exit(status)
    integer, value :: status
  end subroutine exit

  subroutine func(x) 
    complex, value :: x 
    if (abs(imag(x) - 1.0) .ge. 0.1) then
       call exit(1)
    else
       call exit(0)
    endif
  end subroutine func
end program complex
