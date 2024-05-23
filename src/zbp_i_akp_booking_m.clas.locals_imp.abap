CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsupplement.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.
    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatecurrencycode.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalprice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
    ENTITY Booking BY \_BookingSupplement
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    " Loop over all unique tky (TravelID + BookingID)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_booking_group>)
        GROUP BY <travel_booking_group>-%tky.

      " Get highest bookingsupplement_id from bookings belonging to booking
      DATA(lv_max_book_suppl_id) = REDUCE #( INIT max TYPE /dmo/booking_supplement_id
                                             FOR ls_link IN lt_link_data USING KEY entity WHERE ( source-%tky = <travel_booking_group>-%tky )
                                             NEXT max = COND #( WHEN ls_link-target-BookingSupplementId > max
                                                                THEN ls_link-target-BookingSupplementId
                                                                ELSE max )
                                           ).

      " Get highest assigned bookingsupplement_id from incoming entities
      lv_max_book_suppl_id = REDUCE #( INIT max = lv_max_book_suppl_id
                                        FOR ls_entity IN entities USING KEY entity WHERE ( TravelId = <travel_booking_group>-TravelId
                                                                          AND BookingId = <travel_booking_group>-BookingId )
                                        FOR ls_target_supp IN ls_entity-%target
                                        NEXT max = COND #( WHEN ls_target_supp-BookingSupplementId > max
                                                           THEN ls_target_supp-BookingSupplementId
                                                           ELSE max )
                                       ).

      " Loop over all entries in entities with the same TravelID and BookingID
      LOOP AT GROUP <travel_booking_group> ASSIGNING FIELD-SYMBOL(<travel_booking_group_line>).
        LOOP AT <travel_booking_group_line>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>)
                    WHERE BookingSupplementId IS INITIAL.

          APPEND CORRESPONDING #( <booksuppl_wo_numbers> ) TO mapped-bookingsuppl ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
          lv_max_book_suppl_id += 1.
          <mapped_booksuppl>-BookingSupplementId = lv_max_book_suppl_id.


        ENDLOOP.
      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel BY \_Booking
        FIELDS ( BookingStatus )
        WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_bookings).

    result = VALUE #( FOR ls_booking IN lt_bookings
                        (
                            %tky = ls_booking-%tky
                            %features-%assoc-_BookingSupplement = COND #( WHEN ls_booking-BookingStatus EQ 'X'
                                                                          THEN IF_ABAP_behv=>fc-o-disabled
                                                                          ELSE if_abap_behv=>fc-o-enabled )
                        )
                    ).
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Booking
        FIELDS ( BookingStatus )
        WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_bookings).

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<ls_booking>).
      CASE <ls_booking>-BookingStatus.
        WHEN 'N'.  " New
        WHEN 'X'.  " Canceled
        WHEN 'B'.  " Booked

        WHEN OTHERS.
          APPEND VALUE #( %tky = <ls_booking>-%tky ) TO failed-booking.

          APPEND VALUE #( %tky = <ls_booking>-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                     textid = /dmo/cm_flight_messages=>status_invalid
                                     status = <ls_booking>-BookingStatus
                                     severity = if_abap_behv_message=>severity-error )
                          %element-BookingStatus = if_abap_behv=>mk-on
                          %path = VALUE #( travel-travelid    = <ls_booking>-travelid )
                        ) TO reported-booking.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

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
