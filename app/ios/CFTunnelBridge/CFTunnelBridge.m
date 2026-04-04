#import "CFTunnelBridge.h"
#import <CFTunnel/CFTunnel.h>  // gomobile-generated header

@implementation CFTunnelBridge

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(ping:(NSString *)hostname
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  NSString *result = CftunnelPing(hostname);
  resolve(result);
}

@end
