import React, {
  forwardRef,
  Fragment,
  useEffect,
  useImperativeHandle,
  useRef,
  type MutableRefObject,
  type SetStateAction,
  type Dispatch,
} from 'react';

import {
  requireNativeComponent,
  findNodeHandle,
  UIManager,
  Platform,
  NativeEventEmitter,
  NativeModules,
  Text,
  type HostComponent,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-app-restriction' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type NativeComponentProps = {
  show: boolean;
};

type AppRestrictionProps = {
  show: boolean;
  onClosePicker?: () => void;
  onError?: (message: string) => void;
  onSelectionChange?:
    | ((base64Data: string) => void | Dispatch<SetStateAction<string>>)
    | undefined;
  ref?: MutableRefObject<any>;
};

type RefProps = {
  clearRestrictedApps(): void;
  addRestrictedApps(base64Data: string): void;
};

const ComponentName = 'AppRestrictionView';

const NativeComponent: HostComponent<NativeComponentProps> | React.JSX.Element =
  UIManager.getViewManagerConfig(ComponentName) != null ? (
    requireNativeComponent<NativeComponentProps>(ComponentName)
  ) : (
    <Text>{LINKING_ERROR}</Text>
  );

export const AppRestrictionView = forwardRef<RefProps, AppRestrictionProps>(
  (props, ref) => {
    const nativeRef: MutableRefObject<any> = useRef();

    useImperativeHandle(ref, () => {
      return {
        clearRestrictedApps: (): void => {
          UIManager.dispatchViewManagerCommand(
            findNodeHandle(nativeRef.current),
            // @ts-ignore
            UIManager.AppRestrictionView.Commands.clearRestrictedApps,
            []
          );
        },
        addRestrictedApps: (base64Data: string): void => {
          UIManager.dispatchViewManagerCommand(
            findNodeHandle(nativeRef.current),
            // @ts-ignore
            UIManager.AppRestrictionView.Commands.addRestrictedApps,
            [base64Data]
          );
        },
      };
    }, []);

    const onSelectionChange = (data: string): void => {
      props.onSelectionChange?.(data);
    };

    const onClosePicker = (): void => {
      props.onClosePicker?.();
    };

    const onError = (message: string): void => {
      props.onError?.(message);
    };

    useEffect(() => {
      const eventEmitter = new NativeEventEmitter(
        NativeModules.AppRestrictionEventEmitter
      );

      const selectionChangeSubscription = eventEmitter.addListener(
        'onSelectionChange',
        onSelectionChange
      );

      const closeSubscription = eventEmitter.addListener(
        'onClosePicker',
        onClosePicker
      );

      const errorSubscription = eventEmitter.addListener('onError', onError);

      return () => {
        selectionChangeSubscription.remove();
        closeSubscription.remove();
        errorSubscription.remove();
      };
    }, []);
    return (
      <Fragment>
        {/*@ts-ignore*/}
        <NativeComponent ref={nativeRef} show={props.show} />
      </Fragment>
    );
  }
);
