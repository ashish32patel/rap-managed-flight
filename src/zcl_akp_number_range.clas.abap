CLASS zcl_akp_number_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS create_number_range_interval
      IMPORTING
        i_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS get_latest_number
      IMPORTING
        i_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS reset_number_range
      IMPORTING
        i_out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.



CLASS zcl_akp_number_range IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    create_number_range_interval( out ).   "Create interval for Number range object  -- One time for new system.


*    get_latest_number( out ).   "---->Use for test after creating number range interval in above step.

    reset_number_range( out ).   "Reset interval for Number range object to 5000

  ENDMETHOD.

  METHOD reset_number_range.

    TRY.
        cl_numberrange_intervals=>update(
          EXPORTING
            interval  = VALUE #( ( nrrangenr = '01' fromnumber = '00005000' tonumber = '99999999' )  )
            object    = 'ZAKP_NR_TR'
        ).
      CATCH cx_number_ranges INTO DATA(lo_exc).
        "handle exception
        i_out->write( lo_exc->get_text(  ) ).
    ENDTRY.

    i_out->write( |Number range reset done.| ).

  ENDMETHOD.




  METHOD get_latest_number.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*        ignore_buffer     =
            nr_range_nr       = '01'
            object            = 'ZAKP_NR_TR'
            quantity          = 1
*        subobject         =
*        toyear            =
          IMPORTING
            number            = DATA(lv_latest_number)
            returncode        = DATA(lv_return_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found INTO DATA(lo_exception).
        i_out->write( lo_exception->get_text(  ) ).
      CATCH cx_number_ranges INTO DATA(lo_exception1).
        i_out->write( lo_exception1->get_text(  ) ).
    ENDTRY.

    i_out->write( |Latest number is : { lv_latest_number }| ).

  ENDMETHOD.


  METHOD create_number_range_interval.

    "Create interval for Number range object  -- one time for new system.
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = VALUE #( ( nrrangenr = '01' fromnumber = '00005000' tonumber = '99999999' )  )
            object    = 'ZAKP_NR_TR'
*        subobject =
*        option    =
*      IMPORTING
*        error     =
*        error_inf =
*        error_iv  =
*        warning   =
        ).
      CATCH cx_number_ranges INTO DATA(lo_exc).
        "handle exception
        i_out->write( lo_exc->get_text(  ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
