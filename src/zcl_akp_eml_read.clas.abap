CLASS zcl_akp_eml_read DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AKP_EML_READ IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    "Refer to CLASS cl_demo_rap_eml_read_op_fields
**********************************************************************
    "Read operation
    "FROM
    READ ENTITY zi_akp_travel_m
    FROM VALUE #( ( %key-TravelId = '00005000'
                    %control-AgencyId = if_abap_behv=>mk-on
                    %control-CustomerId = if_abap_behv=>mk-on
                    %control-BeginDate = if_abap_behv=>mk-on
                    %control-Description = if_abap_behv=>mk-on
                   ) )
    RESULT DATA(read_from)
    FAILED DATA(failed_from).

    IF failed_from IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = 'Read: FROM : Reads key fields plus fields specified in %control'
                  data = read_from ).

      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.
**********************************************************************
    "Read operation
    "FROM
    READ ENTITY zi_akp_travel_m
    FROM VALUE #( ( %key-TravelId = '00005000'
                   ) )
    RESULT DATA(read_from_without_control)
    FAILED DATA(failed_from_without_control).

    IF failed_from_without_control IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = 'Read: FROM -Without control structure: Reads Only the key fields'
                  data = read_from_without_control ).
      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.
**********************************************************************
    "Read operation
    "FIELDS (...) WITH    : Don't need to explicitly define %control
    READ ENTITY zi_akp_travel_m
    FIELDS ( AgencyId CustomerId BeginDate Description )
    WITH VALUE #( ( %key-TravelId = '00005000' ) )
    RESULT FINAL(read_fields_with)
    FAILED FINAL(failed_fields_with).
    IF failed_fields_with IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = |Read: FIELDS (...) WITH -Don't need to explicitly define %control |
                  data = read_fields_with ).
      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.

    "ALL FIELDS WITH
    READ ENTITY zi_akp_travel_m
    ALL FIELDS
    WITH VALUE #( ( %key-TravelId = '00005000' )
                  ( %key-TravelId = '00005001' )   "One way of reading multiple instances
                 )
    RESULT FINAL(read_all_fields_with)
    FAILED FINAL(failed_all_fields_with).
    IF failed_all_fields_with IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = |READ: ALL FIELDS WITH -Reads all fields, Don't need to explicitly define %control |
                  data = read_all_fields_with ).
      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.
**********************************************************************
    "Read-by-association operation
    "FROM
    READ ENTITY zi_akp_travel_m
    BY \_Booking
    FROM VALUE #( ( %key-TravelId = '00005000'
                    %control-BookingDate = if_abap_behv=>mk-on
                    %control-FlightPrice = if_abap_behv=>mk-on
                    %control-BookingStatus = if_abap_behv=>mk-on
                   ) )
     RESULT FINAL(rba_from)
     FAILED FINAL(failed_rba_from).

    IF failed_rba_from IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = |Read-by-association -FROM |
                  data = rba_from ).
      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.
**********************************************************************
    "Read-by-association operation
    "FIELDS (...) WITH
    READ ENTITY zi_akp_travel_m
    BY \_Booking
    FIELDS ( BookingDate FlightDate FlightPrice BookingStatus )
    WITH VALUE #( ( %key-TravelId = '00005000' ) )
     RESULT FINAL(rba_fields_with)
     LINK FINAL(rba_fields_with_link)
     FAILED FINAL(failed_rba_fields_with).

    IF failed_rba_from IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = |Read by association: FIELDS (...) WITH |
                  data = rba_fields_with ).
      out->write( cl_abap_char_utilities=>newline ).
      out->write( name = |Read by association: LINK Data -check in debug as well  |
            data = rba_fields_with_link ).
      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.
**********************************************************************
    "Read operation  : Long form

    READ ENTITIES OF zi_akp_travel_m

    ENTITY Travel    "In long form we can use the alias name of the entities defined in BDEF
    ALL FIELDS
    WITH VALUE #( ( %key-TravelId = '00005000' ) )
    RESULT DATA(lt_travels)

    ENTITY Booking
    ALL FIELDS
    WITH VALUE #( ( %key-TravelId = '00005000'
                    %key-BookingId = '0010' ) )
    RESULT DATA(lt_bookings)

    FAILED DATA(lt_failed_long).

    IF lt_failed_long IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( name = |Read operation : Long form : Travel data|
                  data = lt_travels ).
      out->write( cl_abap_char_utilities=>newline ).
      out->write( name = |Read operation : Long form : Booking data|
            data = lt_bookings ).
      out->write( cl_abap_char_utilities=>newline ).
    ENDIF.
**********************************************************************
    "Read operation executing a function
    "FROM
    "Refer to CLASS cl_demo_rap_eml_read_op_fields
**********************************************************************
    "Read operation : Dynamic form
    "Refer to CLASS cl_demo_rap_eml_read

    DATA:
      op_tab          TYPE abp_behv_retrievals_tab,  "READ ENTITIES OPERATIONS op_tab
      read_dyn        TYPE TABLE FOR READ IMPORT zi_akp_travel_m,
      read_dyn_result TYPE TABLE FOR READ RESULT zi_akp_travel_m,
      rba_dyn         TYPE TABLE FOR READ IMPORT zi_akp_travel_m\_Booking,
      rba_dyn_result  TYPE TABLE FOR READ RESULT zi_akp_travel_m\_Booking,
      rba_dyn_link    TYPE TABLE FOR READ LINK zi_akp_travel_m\_Booking.


    read_dyn = VALUE #( (
                          %key-TravelId = '00005000'
                          %control-AgencyId = if_abap_behv=>mk-on
                          %control-BeginDate = if_abap_behv=>mk-on
                          %control-EndDate = if_abap_behv=>mk-on
                        ) ).

    rba_dyn = VALUE #( (
                          %key-TravelId = '00005000'
                          %control-BookingDate = if_abap_behv=>mk-on
                          %control-CarrierId = if_abap_behv=>mk-on
                          %control-FlightDate = if_abap_behv=>mk-on
                        ) ).


    op_tab = VALUE #( (
                          op = if_abap_behv=>op-r-read
                          entity_name = 'ZI_AKP_TRAVEL_M'
                          instances = REF #( read_dyn )
                          results = REF #( read_dyn_result )

                       )
                       (
                          op = if_abap_behv=>op-r-read_ba
                          entity_name = 'ZI_AKP_TRAVEL_M'
                          sub_name = '_BOOKING'
                          instances = REF #( rba_dyn )
                          full = abap_true   " Flag: Request RESULTS (not just LINKS) *Not sure ??
                          results = REF #( rba_dyn_result )
                          links = REF #( rba_dyn_link )
*
                       )

              ).


    READ ENTITIES OPERATIONS op_tab FAILED DATA(failed_dyn). "Dynamic READ EML syntax.

    IF failed_dyn IS NOT INITIAL.
      out->write( 'Read failed' ).
    ELSE.
      out->write( 'Read operation : Dynamic form: READ ENTITIES OPERATIONS op_tab' ).
      out->write( read_dyn_result
      )->write( rba_dyn_result
      )->write( rba_dyn_link ).
    ENDIF.







































**********************************************************************

  ENDMETHOD.
ENDCLASS.
