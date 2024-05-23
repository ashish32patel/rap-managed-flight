@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_AKP_BOOKSUPPL_M
  as select from zakp_booksuppl_m
  association        to parent ZI_AKP_BOOOKING_M as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                    and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZI_AKP_TRAVEL_M          as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement        as _Product        on  $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText    as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Associations */
      _Travel,
      _Booking,
      _Product,
      _SupplementText
}
