CLASS zcl_akp_eml_modify DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AKP_EML_MODIFY IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    "Mostly using below declarations to check and verify the structures of the parameters to be used
    DATA: lt_create_travel1 TYPE TABLE FOR CREATE zi_akp_travel_m.
    DATA: lt_create_travel_booking TYPE TABLE FOR CREATE zi_akp_travel_m\_Booking.
    DATA: lt_create_booking_sup TYPE TABLE FOR CREATE zi_akp_boooking_m\_BookingSupplement.
**********************************************************************
    "MODIFY operations with the addition FROM
    "refer cl_demo_rap_eml_modify_oprtns

*    MODIFY ENTITY zi_akp_travel_m
*    CREATE FROM VALUE #( (  %cid = 'cidTvl1'
*                          "no need to pass travelid , as we have early numbering implemneted.
*                         begindate = '20240511'
*                         CustomerId = '2'
*                         %control-BeginDate = if_abap_behv=>mk-on
*                         %control-CustomerId = if_abap_behv=>mk-on
*                         )
*                       )
*    CREATE BY \_Booking
*        FROM VALUE #( ( %cid_ref = 'cidTvl1'
*                        %target = VALUE #(
*                                            (
*                                             %cid = 'cidTvl1Book1'
*                                             %data-bookingdate = '20240511'
*                                             %data-customerid = '4'
*                                             %control-bookingdate = if_abap_behv=>mk-on
*                                             %control-customerid = if_abap_behv=>mk-on
*                                            )
*                                          )
*                       ) )
*
*
*        MAPPED FINAL(mapped)
*        FAILED   FINAL(failed)
*        REPORTED FINAL(reported).
*
*    IF failed IS NOT INITIAL.
*      out->write( failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.
**********************************************************************
*    "MODIFY operations with the addition FROM -- for Travel, Booking, Booking Supplement.
*    MODIFY ENTITIES OF zi_akp_travel_m
*        ENTITY Travel
*            CREATE FROM VALUE #( (  %cid = 'cidTvl1'
*                                  "no need to pass travelid , as we have early numbering implemneted.
*                                 begindate = '20240511'
*                                 CustomerId = '2'
*                                 %control-BeginDate = if_abap_behv=>mk-on
*                                 %control-CustomerId = if_abap_behv=>mk-on
*                                 )
*                               )
*            CREATE BY \_Booking
*                FROM VALUE #( ( %cid_ref = 'cidTvl1'
*                                %target = VALUE #(
*                                                    (
*                                                     %cid = 'cidTvl1Book1'
*                                                     %data-bookingdate = '20240511'
*                                                     %data-customerid = '4'
*                                                     %control-bookingdate = if_abap_behv=>mk-on
*                                                     %control-customerid = if_abap_behv=>mk-on
*                                                    )
*                                                  )
*                               ) )
*
*        ENTITY Booking
*             CREATE BY \_BookingSupplement
*             FROM VALUE #( ( %cid_ref = 'cidTvl1Book1'
*                                %target = VALUE #(
*                                                    (
*                                                     %cid = 'cidTvl1Book1Sup1'
*                                                     %data-supplementid  = 'ML-0021'
*                                                     %control-supplementid = if_abap_behv=>mk-on
*                                                    )
*                                                  )
*                               ) )
*
*        MAPPED FINAL(mapped)
*        FAILED   FINAL(failed)
*        REPORTED FINAL(reported).
*
*    IF failed IS NOT INITIAL.
*      out->write( failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.
**********************************************************************
*    "Create Booking in an existing Travel instance
*    MODIFY ENTITY zi_akp_travel_m
*    CREATE BY \_Booking
*    FROM VALUE #( ( "%cid_ref = 'cidTvl1' -not needed as travelid already present.
*                     travelid = '00005003'
*                                %target = VALUE #(
*                                                    (
*                                                     %cid = 'cidTvlBook'
*                                                     %data-bookingdate = '20240512'
*                                                     %data-customerid = '5'
*                                                     %control-bookingdate = if_abap_behv=>mk-on
*                                                     %control-customerid = if_abap_behv=>mk-on
*                                                    )
*                                                  )
*                               ) )
*
*        MAPPED FINAL(mapped1)
*        FAILED   FINAL(failed1)
*        REPORTED FINAL(reported1).
*    IF failed1 IS NOT INITIAL.
*      out->write( failed1 ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.


**********************************************************************
*    "Delete travel id and compositions
*    MODIFY ENTITY zi_akp_travel_m
*    DELETE FROM VALUE #( ( %key-TravelId = '00005004' ) )
*        FAILED   FINAL(failed_delete)
*        REPORTED FINAL(reported_delete).
*
*    IF failed_delete IS NOT INITIAL.
*      out->write( failed_delete ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

**********************************************************************

    "{ AUTO FILL CID WITH fields_tab }

    "-- here no need to provide cid explicitly,
    "   however this will not work when we also want to create by association

*    MODIFY ENTITY zi_akp_travel_m
*        CREATE AUTO FILL CID WITH VALUE #( (
*                         "%cid = 'cidTvl1'
**                          "no need to pass travelid , as we have early numbering implemneted.
*                         begindate = '20240511'
*                         CustomerId = '2'
*                         %control-BeginDate = if_abap_behv=>mk-on
*                         %control-CustomerId = if_abap_behv=>mk-on
*                         )
*                       )
*    MAPPED FINAL(mapped2)
*    FAILED FINAL(failed2)
*    REPORTED FINAL(reported2).
*    IF failed2 IS NOT INITIAL.
*      out->write( failed2 ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.
**********************************************************************
    "MODIFY operations with the addition FIELDS ( ... ) WITH
    " | { [AUTO FILL CID] FIELDS ( comp1 comp2 ... ) WITH fields_tab }

    " ---- here we don't need to pass the control structure as we explicitly list the fields.
    "refer class cl_demo_rap_eml_modify_oprtns

*    MODIFY ENTITY zi_akp_travel_m
*     UPDATE FIELDS ( AgencyId BeginDate )     "we can use CREATE operation in similar fashion also.
*        WITH VALUE #(
*                      (
*                         %key-TravelId = '00005006'
*                         %data-AgencyId = '070014'
*                         %data-BeginDate = '20240513'
*                       )
*                     )
*    MAPPED FINAL(mapped2)
*    FAILED FINAL(failed2)
*    REPORTED FINAL(reported2).
*    IF failed2 IS NOT INITIAL.
*      out->write( failed2 ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.
**********************************************************************
    "MODIFY operations with the addition SET FIELDS WITH
    " | { [ AUTO FILL CID ] SET FIELDS WITH fields_tab }

    "refer class cl_demo_rap_eml_modify_oprtns
    " -- here we don't need to either fill control structure or specify the fields explicitly.
    " -- not commonly used due to Performance issues...

*    MODIFY ENTITY zi_akp_travel_m
*    UPDATE SET FIELDS WITH    "we can use CREATE operation in similar fashion also.
*             VALUE #(
*                      (
*                         %key-TravelId = '00005006'
*                         %data-AgencyId = '070036'
*                         %data-BeginDate = '20240530'
*                       )
*                     )
*    MAPPED FINAL(mapped2)
*    FAILED FINAL(failed2)
*    REPORTED FINAL(reported2).
*    IF failed2 IS NOT INITIAL.
*      out->write( failed2 ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

**********************************************************************
    "MODIFY ENTITIES OPERATIONS op_tab
    "Dynamic Modify operations.
    "Refer CLASS cl_demo_rap_eml_modify

    DATA: lt_op_tab             TYPE abp_behv_changes_tab,

          lt_create_travel      TYPE TABLE FOR CREATE zi_akp_travel_m,
          lt_update_travel      TYPE TABLE FOR UPDATE zi_akp_travel_m,
          lt_delete_travel      TYPE TABLE FOR DELETE zi_akp_travel_m,

          lt_cba_travel_booking TYPE TABLE FOR CREATE zi_akp_travel_m\_Booking,
          lt_update_booking     TYPE TABLE FOR UPDATE zi_akp_boooking_m,
          lt_delete_booking     TYPE TABLE FOR DELETE zi_akp_boooking_m.


    lt_create_travel = VALUE #(
                            (  %cid = 'cidTvl1'
                                    "no need to pass travelid , as we have early numbering implemneted.
                               begindate = '20240501'
                               CustomerId = '7'
                               %control-BeginDate = if_abap_behv=>mk-on
                               %control-CustomerId = if_abap_behv=>mk-on
                             )
                            (  %cid = 'cidTvl2'
                                    "no need to pass travelid , as we have early numbering implemneted.
                               begindate = '20240501'
                               CustomerId = '7'
                               %control-BeginDate = if_abap_behv=>mk-on
                               %control-CustomerId = if_abap_behv=>mk-on
                             )
                            (  %cid = 'cidTvl3'
                                    "no need to pass travelid , as we have early numbering implemneted.
                               begindate = '20240501'
                               CustomerId = '7'
                               %control-BeginDate = if_abap_behv=>mk-on
                               %control-CustomerId = if_abap_behv=>mk-on
                             )
                          ).

    lt_update_travel = VALUE #(    (
                                    %cid_ref = 'cidTvl2'
                                    CustomerId = '8'
                                    %control-CustomerId = if_abap_behv=>mk-on
                                    )
                              ).
    lt_cba_travel_booking = VALUE #(
                                (
                                  %cid_ref =   'cidTvl2'
                                  %target = VALUE #(
                                                    ( %cid = 'cidTvl2Book1'
                                                      %data-bookingdate = '20240511'
                                                      %data-customerid = '4'
                                                      %control-bookingdate = if_abap_behv=>mk-on
                                                      %control-customerid = if_abap_behv=>mk-on
                                                    )
                                                    ( %cid = 'cidTvl2Book2'
                                                      %data-bookingdate = '20240512'
                                                      %data-customerid = '5'
                                                      %control-bookingdate = if_abap_behv=>mk-on
                                                      %control-customerid = if_abap_behv=>mk-on
                                                    )

                                                )
                                )
                                (
                                  %cid_ref =   'cidTvl3'
                                  %target = VALUE #(
                                                    ( %cid = 'cidTvl3Book1'
                                                      %data-bookingdate = '20240511'
                                                      %data-customerid = '4'
                                                      %control-bookingdate = if_abap_behv=>mk-on
                                                      %control-customerid = if_abap_behv=>mk-on
                                                    )
                                                )
                                )
                             ).

    lt_op_tab = VALUE #(
                         (
                            op = if_abap_behv=>op-m-create
                            entity_name = 'ZI_AKP_TRAVEL_M'
                            instances = REF #( lt_create_travel )
                         )
                         (
                            op = if_abap_behv=>op-m-update
                            entity_name = 'ZI_AKP_TRAVEL_M'
                            instances = REF #( lt_update_travel )
                         )
                         (
                            op = if_abap_behv=>op-m-create_ba
                            entity_name = 'ZI_AKP_TRAVEL_M'
                            sub_name = '_BOOKING'
                            instances = REF #( lt_cba_travel_booking )
                         )

                       ).


    MODIFY ENTITIES OPERATIONS lt_op_tab
      FAILED   FINAL(fail_mod3)
      REPORTED FINAL(rep_mod3)
      MAPPED   FINAL(map_mod3).

    IF fail_mod3 IS NOT INITIAL.
      out->write( fail_mod3 ).
    ELSE.
      COMMIT ENTITIES.
    ENDIF.
**********************************************************************


  ENDMETHOD.
ENDCLASS.
