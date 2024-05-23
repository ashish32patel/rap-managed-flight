CLASS lhc_bookingsuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSuppl~calculateTotalPrice.

ENDCLASS.

CLASS lhc_bookingsuppl IMPLEMENTATION.

  METHOD calculateTotalPrice.
    DATA: lt_action_keys TYPE STANDARD TABLE OF zi_akp_travel_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    lt_action_keys = CORRESPONDING #( keys DISCARDING DUPLICATES ).

    MODIFY ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
        EXECUTE reCalcTotalPrice
        FROM CORRESPONDING #( lt_action_keys ).


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
