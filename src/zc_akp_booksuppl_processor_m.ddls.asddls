@EndUserText.label: 'Booking Supplement Projection View-Processor app'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_AKP_BOOKSUPPL_PROCESSOR_M
  as projection on ZI_AKP_BOOKSUPPL_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplementDescription' ]
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZC_AKP_BOOOKING_PROCESSOR_M,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZC_AKP_TRAVEL_PROCESSOR_M
}
