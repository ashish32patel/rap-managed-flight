CLASS zcl_akp_loadtestdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AKP_LOADTESTDATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DELETE FROM zakp_travel_m.
    DELETE FROM zakp_boooking_m.
    DELETE FROM zakp_booksuppl_m.

    INSERT zakp_travel_m
    FROM  ( SELECT * FROM /dmo/travel_m  ).

    INSERT zakp_boooking_m
    FROM  ( SELECT * FROM /dmo/booking_m  ).

    INSERT zakp_booksuppl_m
    FROM  ( SELECT * FROM /dmo/booksuppl_m ).

    out->write( `Data loaded successfully in tables` ).

    COMMIT WORK.



  ENDMETHOD.
ENDCLASS.
