  @echo off
  setlocal



  rem ================================================
  rem t@sk
  rem - command support script
  rem ================================================

  if /i "%~x0" equ ".bat" goto :TASK_CALL_MAIN
  goto :TASK_BEGIN



:TASK_HELP

  echo USAGE :
  echo     %~n0 /?
  echo     %~n0 [ /f ***.t@sk ][ /s ][ /p ][ :target1 [ :target2 [ ... ] ] ]
  echo     %~n0 [ /f ***.t@sk ][ /g ^| /v ^| /l ]
  echo ARGS :
  echo     - /? ........ show this help
  echo     - /f ........ your task file     - /g ........ generate task file   
  echo     - /s ........ no information     - /v ........ generate command file
  echo     - /p ........ pause at the end   - /l ........ show task list
  echo     - :target ... target tasks
  echo HOW TO USE :
  echo     [1] Execute 't@sk /g' command to generate sample task file 'task.t@sk'.
  echo     [2] Edit task file. You use following environment variables.
  echo     [3] Execute 't@sk' to run task file.
  echo ENVIRONMENT VARIABLES :
  echo     %%task_depend_on%% :target1 [ :target2 [ ... ] ]
  echo     %%task_exit%%
  echo     %%task_exit_if_error%%
  echo     %%task_exit_with%% [ result ]
  echo REMARKS :
  echo     - Environment variables TASK_* is reserved.

  exit /b 0



:TASK_SAMPLE

  echo :ALL
  echo   %%task_depend_on%% :TASK1 :TASK2
  echo   %%task_exit_if_error%%
  echo   echo task ALL
  echo   %%task_exit%%
  echo.
  echo :TASK1
  echo   %%task_depend_on%% :TASK11 :TASK12
  echo   %%task_exit_if_error%%
  echo   echo task TASK1
  echo   %%task_exit%%
  echo.
  echo :TASK2
  echo   %%task_depend_on%% :TASK21 :TASK22
  echo   %%task_exit_if_error%%
  echo   echo task TASK2
  echo   %%task_exit%%
  echo.
  echo :TASK11
  echo   echo task TASK11
  echo   %%task_exit%%
  echo.
  echo :TASK12
  echo   echo task TASK12
  echo   %%task_exit%%
  echo.
  echo :TASK21
  echo   echo task TASK21
  echo   %%task_exit%%
  echo.
  echo :TASK22
  echo   echo task TASK22
  echo   %%task_exit%%
  echo.

  exit /b 0



:TASK_BEGIN

  rem ======== default task file ========

  set TASK_FILE=task.t@sk
  set TASK_TASKS=



:TASK_ARG_BEGIN

  rem ======== help option ========

  if "%1" equ "/?" (
    set TASK_HELP=%1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== task file option ========

  if /i "%1" equ "/f" (
    rem === %~s2‚ðŽg‚¤‚ÆŠg’£Žq‚ªˆÙí(.T@S@sk)‚Æ‚È‚é‚Ì‚ÅŒÂ•Ê‚É‘g‚Ý—§‚Ä
    set TASK_FILE=%~sd2%~sp2%~n2%~x2
    shift /1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== silent option ========

  if /i "%1" equ "/s" (
    set TASK_SILENT=%1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== pause option ========

  if /i "%1" equ "/p" (
    set TASK_PAUSE=%1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== generate option ========

  if /i "%1" equ "/g" (
    set TASK_GENERATE=%1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== verbose option ========

  if /i "%1" equ "/v" (
    set TASK_VERBOSE=%1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== task list option ========

  if /i "%1" equ "/l" (
    set TASK_LIST=%1
    shift /1
    goto :TASK_ARG_NEXT
  )

  rem ======== tasks ========

  set TASK_TASKS=%TASK_TASKS% %1
  shift /1
  goto :TASK_ARG_NEXT

:TASK_ARG_NEXT

  if "%1" neq "" goto :TASK_ARG_BEGIN

:TASK_ARG_END



  rem ======== show help and exit ========

  if "%TASK_HELP%" neq "" (
    call :TASK_HELP
    exit /b 0
  )

  rem ======== check leftovers ========

  dir *.t@sk.bat 1>NUL 2>NUL
  if "%ERRORLEVEL%" equ "0" (
    echo ### error : '***.t@sk.bat' detected.
    echo ###         cleaned up.
    echo ###         retry again.
    del *.t@sk.bat
    if "%TASK_PAUSE%" neq "" pause
    exit /b 901
  )

  rem ======== check task file ========

  if "%TASK_FILE%" equ "" (
    echo ### error : task file is not specified.
    echo ###         see following usage.
    echo.
    call :TASK_HELP
    if "%TASK_PAUSE%" neq "" pause
    exit /b 902
  )

  rem ======== generate sample task file and exit ========

  if "%TASK_GENERATE%" neq "" (
    if exist "%TASK_FILE%" (
      echo ### error : '%TASK_FILE%' already exists.
      if "%TASK_PAUSE%" neq "" pause
      exit /b 903
    ) else (
      call :TASK_SAMPLE > %TASK_FILE%
      if "%TASK_SILENT%" equ "" echo ### task file : '%TASK_FILE%' generated.
      exit /b 0
    )
  )

  rem ======== check task file ========

  if not exist "%TASK_FILE%" (
    echo ### error : '%TASK_FILE%' is not found in current directory.
    echo ###         generate task file to execute 't@sk /g' command.
    echo ###         retry again.
    echo.
    call :TASK_HELP
    if "%TASK_PAUSE%" neq "" pause
    exit /b 904
  )

  rem ======== grep and exit if task list ========

  if "%TASK_LIST%" neq "" (
    if "%TASK_SILENT%" equ "" echo ### task list :
    for /f "delims=:" %%l in ('findstr /B : %TASK_FILE%') do (
      echo :%%l
    )
    exit /b 0
  )

  rem ======== generate command file ========

  type %~s0        >  %TASK_FILE%.bat
  type %TASK_FILE% >> %TASK_FILE%.bat

  rem ======== copy command file and exit if verbose ========

  if "%TASK_VERBOSE%" neq "" (
    if "%TASK_SILENT%" equ "" echo ### command file : '%TASK_FILE%.bat' generated.
    copy %TASK_FILE%.bat %TASK_FILE%.cmd 1>NUL 2>NUL
    del %TASK_FILE%.bat
    exit /b 0
  )

  rem ======== execute task file ========

  set TASK_ERRORLEVEL=0
  call %TASK_FILE%.bat %TASK_TASKS%
  set TASK_ERRORLEVEL=%ERRORLEVEL%
  del %TASK_FILE%.bat

  rem ======== pause if pause ========

  if "%TASK_PAUSE%" neq "" pause

:TASK_END

  exit /b %TASK_ERRORLEVEL%



:TASK_CALL_MAIN

  if "%TASK_SILENT%" equ "" echo ### task file : %~n0
  set task_depend_on=call :TASK_CALL_TARGET
  set task_exit=exit /b "^%ERRORLEVEL^%" 
  set task_exit_with=exit /b 
  set task_exit_if_error=if ERRORLEVEL 1 exit /b "^%ERRORLEVEL^%" 
  set TASK_TARGET=:[default]
  if "%1" neq "" (
    set TASK_TARGET=%*
  )

  if "%TASK_SILENT%" equ "" echo ### directory : %CD%
  if "%TASK_SILENT%" equ "" echo ### arguments : %*
  if "%TASK_SILENT%" equ "" echo ### timestamp : %DATE%T%TIME: =0%
  if "%TASK_SILENT%" equ "" echo ### main target : '%TASK_TARGET%'
  call :TASK_CALL_TARGET %TASK_TARGET%
  if "%TASK_SILENT%" equ "" echo ### main return : '%TASK_TARGET%' =^> %ERRORLEVEL%
  if "%TASK_SILENT%" equ "" echo ### timestamp : %DATE%T%TIME: =0%
  if "%ERRORLEVEL%" equ "0" (
    if "%TASK_SILENT%" equ "" echo ### main result : success !!!
  ) else (
    if "%TASK_SILENT%" equ "" echo ### main result : failure ...
  )
  exit /b %ERRORLEVEL%



:TASK_CALL_TARGET

  set TASK_INDENT=  %TASK_INDENT%

:TASK_TARGE_BEGIN
  
  set __%1__ 1>NUL 2>NUL
  if "%ERRORLEVEL%" equ "0" goto :TASK_TARGE_NEXT
  set __%1__=%1
  
  if "%TASK_SILENT%" equ "" echo ### %TASK_INDENT%sub target : '%1'
  set TASK_ERRORLEVEL=0
  call %1
  set TASK_ERRORLEVEL=%ERRORLEVEL%
  if "%TASK_SILENT%" equ "" echo ### %TASK_INDENT%sub return : '%1' =^> %TASK_ERRORLEVEL%
  if "%TASK_ERRORLEVEL%" neq "0" goto :TASK_TARGE_END
  
:TASK_TARGE_NEXT

  shift
  if "%1" neq "" goto TASK_TARGE_BEGIN

:TASK_TARGE_END

  set TASK_INDENT=%TASK_INDENT:~0,-2%
  exit /b %TASK_ERRORLEVEL%



:[default]

