import { NativeModules } from 'react-native';

const { CFTunnelBridge } = NativeModules;

export const CFTunnel = {
  ping: (hostname: string): Promise<string> => {
    return CFTunnelBridge.ping(hostname);
  },
};
