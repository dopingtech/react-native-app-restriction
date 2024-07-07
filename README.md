# react-native-app-restriction

apps restriction

## Installation

```sh
yarn add react-native-app-restriction
```

## Usage


```js
import { useEffect, useRef, useState } from 'react';
import { AppState, StyleSheet, Switch, Text, TouchableOpacity, View } from 'react-native';

import { AppRestrictionView } from 'react-native-app-restriction';


export default function App(): Element {
  const [base64Data, setBase64Data] = useState<any>(null);
  const [showPicker, setShowPicker] = useState<any>(false);
  const [disableAppRestriction, setDisableAppRestriction] = useState<any>(true);

  const appRestrictionRef: MutableRefObject<any> = useRef();

  useEffect(() => {
    if (base64Data) {
      setTimeout(() => {
        console.log('add base64Data');
        appRestrictionRef.current?.addRestrictedApps(base64Data);
      }, 5000);
    }

    const subscription = AppState.addEventListener(
      'change',
      (nextAppState: string) => {
        if (
          disableAppRestriction &&
          (nextAppState === 'inactive' || nextAppState === 'background')
        ) {
          appRestrictionRef.current?.clearRestrictedApps();
          console.log('clearRestrictedApps');
        } else if (base64Data) {
          appRestrictionRef.current?.addRestrictedApps(base64Data);
          console.log('addRestrictedApps');
        }
      }
    );

    return () => {
      subscription.remove();
    };
  }, [base64Data, disableAppRestriction]);

  return (
    <View style={styles.container}>
      <TouchableOpacity
        style={styles.showButton}
        onPress={() => setShowPicker(true)}
      >
        <Text>Open Activities Picker</Text>
      </TouchableOpacity>

      <View style={styles.row}>
        <Text>Disable Restriction when app is inactive or closed</Text>
        <Switch
          onValueChange={(value) => setDisableAppRestriction(value)}
          value={disableAppRestriction}
        />
      </View>

      <AppRestrictionView
        ref={appRestrictionRef}
        show={showPicker}
        onClosePicker={() => setShowPicker(false)}
        onSelectionChange={setBase64Data}
        onError={(message) => console.log(message)}
      />
    </View>
  );
}
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
